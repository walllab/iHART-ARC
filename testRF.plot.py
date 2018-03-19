#!/usr/bin/env python
import sys
import glob
import pandas as pd
import matplotlib as mpl
mpl.use('agg')
import matplotlib.pyplot as plt
from sklearn.metrics import precision_recall_curve, roc_curve
from sklearn.metrics import roc_auc_score, f1_score, precision_score, recall_score


def init_figure(setAxisRange=True):
    fig, ax = plt.subplots(dpi=600)

    if setAxisRange:
        plt.axis([-0.01, 1.01, -0.01, 1.01])

    ax.xaxis.set_minor_locator(mpl.ticker.AutoMinorLocator()) # set minor ticks
    ax.yaxis.set_minor_locator(mpl.ticker.AutoMinorLocator())

    ax.grid(which='major', ls='solid',  alpha=0.5)  # show grid on both axes
    ax.grid(which='minor', ls='dotted', alpha=0.4)

    ax.spines['right'].set_visible(False)
    ax.spines['top'  ].set_visible(False)

    return fig, ax


def draw_threshold(thr, pre, rec):
    fig, ax = init_figure()
    plt.plot(thr, pre[:-1], 'b-', label='Precision')
    plt.plot(thr, rec[:-1], 'r-', label='Recall')
    plt.xlabel('Threshold')
    plt.ylabel('Precision or Recall')
    plt.legend(loc='lower left')
    plt.savefig('test.pr-re-thr.png')


def draw_precision_recall(thr, pre, rec):
    fig, ax = init_figure()
    plt.plot(rec, pre, 'b-', label='Precision-Recall')
    plt.plot(rec[:-1], thr, 'r-', label='Threshold')
    plt.xlabel('Recall')
    plt.ylabel('Precision')
    # plt.title('Precision-Recall Curve for Test Set')
    plt.legend(loc='lower left')
    plt.savefig('test.pr-re.png')


def draw_f1_score(thr, f1):
    fig, ax = init_figure()
    plt.plot(thr, f1[:-1], 'b-', label='F1 Score')
    plt.xlabel('Threshold')
    plt.ylabel('F1 Score')
    plt.savefig('test.f1.png')


def draw_roc_curve(fpr, tpr, thr):
    fig, ax = init_figure()

    plt.plot(fpr, tpr, 'b-', label='ROC curve')
    plt.plot(fpr, thr, 'r-', label='Threshold')
    plt.xlabel('False Positive rate(1 - Specificity)')
    plt.ylabel('True Positive rate (Sensitivity)')
    # plt.title('ROC Curve for Test Set')
    plt.legend(loc='center right')
    plt.savefig('test.roc.png')


def draw_histograms(data):
    allProb = data['prob']
    posProb = [ data['prob'][i] for i, j in enumerate(data['y']) if j==1 ]
    negProb = [ data['prob'][i] for i, j in enumerate(data['y']) if j==0 ]

    fig, ax = init_figure(setAxisRange=False)
    plt.hist(allProb)
    plt.savefig('test.hist.all.png')

    fig, ax = init_figure(setAxisRange=False)
    plt.hist(posProb)
    plt.savefig('test.hist.pos.png')

    fig, ax = init_figure(setAxisRange=False)
    plt.hist(negProb)
    plt.savefig('test.hist.neg.png')


def main():
    inputFile = "./test.tsv" if len(sys.argv)==1 else sys.argv[1]

    # make testing figures if there is "test.tsv" file in the current directory
    if not glob.glob(inputFile):
        print "Cannot find %s file" %(inputFile)
        sys.exit(1)

    data = pd.read_csv(inputFile, sep="\t")

    pre, rec, thr = precision_recall_curve(data["y"], data["prob"])
    f1 = (2 * pre * rec) / (pre + rec)

    draw_threshold       (thr, pre, rec)
    draw_precision_recall(thr, pre, rec)
    draw_f1_score        (thr, f1)

    fpr, tpr, thr = roc_curve(data["y"], data['prob'])
    draw_roc_curve(fpr, tpr, thr)

    draw_histograms(data)


if __name__ == "__main__":
    main()
